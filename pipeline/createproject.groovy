
def createProject(project, jenkinsProject, imageStreamProject) {
    try {
        // try to create the project
        echo "Creating project ${project} if it does not exist yet"
        openshift.newProject(project, "--display-name", project)
        echo "Project ${project} has been created"
    } catch (e) {
        echo "${e}"
        echo "Check error.. but it could be that the project already exists... skkiping step"
    }
    // TODO To be decided.. => if the project was not created by jenkins sa,
    //      then, it is vey likely that its sa doesnt have admin or edit role. If it was created by jenkins, jenkins sa will have admin role
    // openshift.policy("add-role-to-user", "edit", "system:serviceaccount:${jenkinsProject}:jenkins", "-n", project)
    // if project and imageStreamProject are different, add system:image-puller role to project sa
    if (!project.equals(imageStreamProject)) {
        openshift.policy("add-role-to-group", "system:image-puller", "system:serviceaccounts:${project}", "-n", imageStreamProject)
    }
}

return this
