
upload_init_body='{ "registerUploadRequest": { "recipes": [ "urn:li:digitalmediaRecipe:feedshare-image" ], "owner": "urn:li:person:jzEm-jsKUu", "serviceRelationships": [ { "relationshipType": "OWNER", "identifier": "urn:li:userGeneratedContent" } ] } }'

git show --name-only --oneline HEAD |
  rg 'post-[0-9]*/*' -o $1 | 
  uniq | 
  while read file; 
  do 
    image_urn=$(test -f "./${file}image.png" && 
      curl -H "Authorization: Bearer $LINKEDIN_ACCESS_TOKEN" \
         -H "Connection: Keep-Alive" \
         -d "${upload_init_body}" \
         -H "X-Restli-Protocol-Version: 2.0.0" \
         -H "Content-Type: application/json" \
         -X POST \
         -s https://api.linkedin.com/v2/assets\?action\=registerUpload | \
           jq \
           '.value.uploadMechanism."com.linkedin.digitalmedia.uploading.MediaUploadHttpRequest".uploadUrl, .value.asset' | \
           xargs bash -c 'curl -s \
           --upload-file "./'${file}'image.png" \
           -H "Authorization: Bearer $LINKEDIN_ACCESS_TOKEN" $0 && echo $1');
     post_body=$( [ "$image_urn" != "" ] && echo '
       {
    "author": "urn:li:person:jzEm-jsKUu",
    "lifecycleState": "PUBLISHED",
    "specificContent": {
        "com.linkedin.ugc.ShareContent": {
            "shareCommentary": {
            "text": "'$(cat ./${file}/content.txt)'"
              },
            "shareMediaCategory": "IMAGE",
            "media": [
                {
                    "status": "READY",
                    "description": {
                        "text": "none"
                    },
                    "media": "'$image_urn'",
                    "title": {
                        "text": "none"
                    }
                }
            ]
        }
    },
    "visibility": {
        "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"
    }
}
     ' ||
    echo '
    { "author": "urn:li:person:jzEm-jsKUu", 
      "lifecycleState": "PUBLISHED", 
      "specificContent": { 
      "com.linkedin.ugc.ShareContent": { 
      "shareCommentary": { 
      "text": "'$(cat ./${file}/content.txt)'" }, 
      "shareMediaCategory": "NONE" } }, 
      "visibility": { 
      "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC" } }
    '
   );

  curl -H "Authorization: Bearer $LINKEDIN_ACCESS_TOKEN" \
    -H "Connection: Keep-Alive" \
    -H "X-Restli-Protocol-Version: 2.0.0" \
    -H "Content-Type: application/json" \
    -d "$post_body" \
    -X POST https://api.linkedin.com/v2/ugcPosts;

  done
Footer
© 2022 GitHub, Inc.
Footer navigation
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
social-posts/post.sh at master · 64BitAsura/social-posts
