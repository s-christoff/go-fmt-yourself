#!/bin/bash
##copied (inspired?) by /sjkaliski/go-github-actions/
cd "${GO_WORKING_DIR:-.}"

# Iterate through each unformatted file.
OUTPUT=""
for FILE in $ISSUE_FILES; do
DIFF=$(gofmt -d -e "${FILE}")
OUTPUT="$OUTPUT
\`${FILE}\`
\`\`\`diff
$DIFF
\`\`\`
"
done

# acutally modify the files because you're lazy
go fmt .

# Post results back as comment.
COMMENT="#### found some garbage of urs m8 
\`go fmt\`
$OUTPUT
"
PAYLOAD=$(echo '{}' | jq --arg body "$COMMENT" '.body = $body')
COMMENTS_URL=$(cat /github/workflow/event.json | jq -r .pull_request.comments_url)

if [ "COMMENTS_URL" != null ]; then
  curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/json" --data "$PAYLOAD" "$COMMENTS_URL" > /dev/null
fi


exit $SUCCESS


