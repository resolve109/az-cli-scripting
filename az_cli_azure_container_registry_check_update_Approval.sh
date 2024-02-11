#each function in the code can be run independently for testing purposes. 
#You can call each function individually and provide the required arguments to test their functionality. 
#For example, you can call the get_registry_list function to retrieve the list of Azure Container Registries, 
#or call the check_patching_required function to check if a specific registry requires OS and framework patching.



#!/bin/bash

# Function to get the list of Azure Container Registries
get_registry_list() {
    az acr list --query "[].name" -o tsv  # Get the list of Azure Container Registries using Azure CLI and output as tab-separated values
}

# Function to check if the registry needs OS and framework patching
check_patching_required() {
    local registry=$1
    az acr check-health --name "$registry" --yes -o tsv --query "osAndFrameworkPatchAvailable"  # Check if the registry requires OS and framework patching using Azure CLI and output as tab-separated values
}

# Function to update the registry
update_registry() {
    local registry=$1
    echo "Updating $registry..."
    
    # Update the tags for a specific image
    az acr repository update --name "$registry" --image <image-name>:<new-tag>  # Replace <image-name> with the name of the image and <new-tag> with the new tag
}

# Function to check and update a single registry
check_and_update_registry() {
    local registry=$1
    echo "Checking registry: $registry"

    local patching_required=$(check_patching_required "$registry")  # Check if the registry requires patching

    if [ "$patching_required" == "true" ]; then  # If patching is required
        echo "OS and framework patching is required for $registry"
        update_registry "$registry"  # Update the registry
    else
        echo "No OS and framework patching required for $registry"
    fi

    echo
}

# Function to check and update multiple registries
check_and_update_registries() {
    local registry_list=("$@")  # Get the list of registries as input
    
    # Loop through each registry
    for registry in "${registry_list[@]}"; do
        check_and_update_registry "$registry"  # Check and update each registry
    done
}

# Main function
main() {
    local registry_list=$(get_registry_list)  # Get the list of Azure Container Registries

    # Check and update all registries
    check_and_update_registries "${registry_list[@]}"  # Check and update each registry in the list
}

# Call the main function
main  # Execute the main function
