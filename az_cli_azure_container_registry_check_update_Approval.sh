# This YAML file defines an Azure Pipeline that checks if Azure Container Registries need to be updated.
# The pipeline is triggered by changes to the main branch.
# It consists of a job named "emailContainerRegistries" that runs on an Ubuntu VM.
# The job includes two tasks: an Azure CLI task and a PublishBuildArtifacts task.
# The Azure CLI task retrieves a list of container registries and checks if they need patching.
# The results are written to an output file.
# The PublishBuildArtifacts task publishes the output file as an artifact named "RegistriesToUpdate".
# The artifact is published to a container.
# This line specifies the trigger for the pipeline, which is a change to the main branch.
# This is a user-defined setting.
trigger:
  branches:
    include:
      - main

# This line starts the definition of a job. The job's name is user-defined.
jobs:
  - job: emailContainerRegistries
    # This line sets a user-defined display name for the job.
    displayName: Email Container Registries
    # This line specifies the type of VM to use for the job. This is a user-defined setting.
    pool:
      vmImage: 'ubuntu-latest'

    # This line starts the definition of the steps that the job will run. 
    steps:
      # This line starts the definition of an Azure CLI task. The display name is user-defined.
      - task: AzureCLI@2
        displayName: 'Get Azure Container Registries'
        # These lines are user-defined inputs to the Azure CLI task.
        inputs:
          azureSubscription: '<Azure Subscription>'
          scriptType: 'bash'
          scriptLocation: 'inlineScript'
          # This line starts the definition of the script that the Azure CLI task will run.
          # The script is user-defined.
          inlineScript: |
            # This function is user-defined. It uses the Azure CLI to get a list of registries.
            get_registry_list() {
              az acr list --query "[].name" -o tsv
            }

            # This function is user-defined. It uses the Azure CLI to check if a registry needs patching.
            check_patching_required() {
              local registry=$1
              az acr check-health --name "$registry" --yes -o tsv --query "osAndFrameworkPatchAvailable"
            }

            # This function is user-defined. It calls the other functions and writes their output to a file.
            main() {
              local registry_list=$(get_registry_list)
              local updated_registries=()
              for registry in "${registry_list[@]}"; do
                local patching_required=$(check_patching_required "$registry")
                if [ "$patching_required" == "true" ]; then
                  updated_registries+=("$registry")
                fi
              done
              # These lines are generated by the computer as the script runs.
              echo "Registries that need to be updated:" > output.txt
              for registry in "${updated_registries[@]}"; do
                echo "Registry: $registry" >> output.txt
              done
            }

            # This line is user-defined. It calls the main function to start the script.
            main

      # This line starts the definition of a PublishBuildArtifacts task. The inputs are user-defined.
      - task: PublishBuildArtifacts@1
        inputs:
          # These lines specify the path to the file to publish and the name of the artifact.
          # These are user-defined settings.
          pathtoPublish: 'output.txt'
          artifactName: 'RegistriesToUpdate'
          # This line specifies where to publish the artifact. This is a user-defined setting.
          publishLocation: 'Container'
