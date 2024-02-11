#!/bin/bash

# Get the list of Azure Container Registries
registry_list=$(az acr list --query "[].name" -o tsv)

# Loop through each registry
for registry in $registry_list; do
    echo "Checking registry: $registry"

    # Check if the registry needs OS and framework patching
    patching_required=$(az acr check-health --name $registry --yes -o tsv --query "osAndFrameworkPatchAvailable")

    if [ "$patching_required" == "true" ]; then
        echo "OS and framework patching is required for $registry"
        read -p "Do you want to approve the update? (Y/N): " approval

        if [ "$approval" == "Y" ] || [ "$approval" == "y" ]; then
            echo "Updating $registry..."
            # Add your update command here
        else
            echo "Skipping update for $registry"
        fi
    else
        echo "No OS and framework patching required for $registry"
    fi

    echo
done
