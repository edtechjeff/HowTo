# Delete Assigment of AutoPilot Deployment Profile using Graph Explorer

## In order for this to work, you need to be logged on with the correct permissions and also after logging on you may have to change the permissions or add admin consent

- Go to the following website
    - https://developer.microsoft.com/en-us/graph/graph-explorer

- Step 1: List All Deployment Profiles
    - Method: GET
    - URL:
    ```
    https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeploymentProfiles
    ```
- Run the query
- Copy the ID of the profile you want to unassign

- Step 2: List Profile Assignments
    - Method: GET
    - URL:
    ```
    https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeploymentProfiles/{profileId}/assignments
    ```
- Replace {profileId} with the ID from step 1.
- Run the query
- You'll get one or more assignment objects, each with their own id

- Step 3 Delete the assignment
    - Method: Delete
    - URL:
    ```
    https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeploymentProfiles/{profileId}/assignments/{assignmentId}
    ```
- Replace both {profileId} and {assignmentId} with the correct values
- Click Run Query
- If successful, you’ll get a 204 No Content response (meaning deletion succeeded)


- OPTIONAL: Delete the Profile 
    - Once all assignments are removed
    - Method: DELETE
    - URL:
    ```
    https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeploymentProfiles/{profileId}
    ```
 -  This will delete the profile entirely  


