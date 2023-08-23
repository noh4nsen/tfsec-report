#!/bin/bash 

set -euo pipefail

projects=$1
report="[]"

if [[ $projects == *null* ]]; then
    echo "--- No projects to run tfsec on ---"
    echo "tfsec_report=$(echo $report)" >> $GITHUB_OUTPUT
    exit 0
fi

while read -r project; do
    echo "--- Running tfsec on $project ---"

    cd $GITHUB_WORKSPACE/$project
    report=$(jq --argjson obj "$(jq -n -c --arg "project" $project '$ARGS.named' --argjson "report" "$(tfsec --format=json)" '$ARGS.named')" '. + [$obj]' <<< "$report")

    echo -e "--- Finished Report on $project ---\n"
done < <(echo $projects | tr -d "'" | jq -r '.projects[]' )

encoded_report=$(echo -n $report | base64)
echo -n $encoded_report

echo -n "tfsec_report=$(echo -n $encoded_report)" >> $GITHUB_OUTPUT