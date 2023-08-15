#!/bin/bash 

set -euo pipefail

projects=$1
report="[]"

if [[ $projects == *null* ]]; then
    echo "--- No projects to run tfsec on ---"
    echo "tfsec_report='$(echo $report)'" >> $GITHUB_OUTPUT
    exit 0
fi

while read -r project; do
    echo "--- Running tfsec on $project ---"

    cd $GITHUB_WORKSPACE/$project
    report=$(jq --argjson obj "$(jq -n -c --argjson $project "$(tfsec --format=json)" '$ARGS.named')" '. + [$obj]' <<< "$report")

    echo -e "--- Finished Report on $project ---\n"
done < <(echo $projects | tr -d "'" | jq -r '.projects[]' )


echo "tfsec_report='$(echo $report)'" >> $GITHUB_OUTPUT