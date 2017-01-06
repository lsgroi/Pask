using System.Collections.Generic;
using System.Linq;
using EnvDTE;
using EnvDTE80;

namespace Pask.Extension.ProjectTemplateWizard
{
    public static class EnvDteExtensions
    {
        // List of project type guids.
        // https://www.codeproject.com/reference/720512/list-of-visual-studio-project-type-guids
        public static readonly string SolutionFolderType = "{2150E333-8FDC-42A3-9474-1A3956D46DE8}";
        public static readonly string[] SolutionItemTypes =
        {
            Constants.vsProjectKindSolutionItems,
            Constants.vsProjectItemsKindSolutionItems,
            Constants.vsProjectItemKindSolutionItems
        };
        public static readonly string CSharpType = "{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}";

        // Gets all project in a solution
        public static List<Project> GetProjects(Solution2 solution)
        {
            var projects = new List<Project>();

            for (var i = 1; i <= solution.Projects.Count; i++)
            {
                var project = solution.Projects.Item(i);

                if (SolutionItemTypes.Contains(project.Kind))
                {
                    projects.AddRange(GetSolutionFolderProjects(project));
                }
                else if (project.Kind != Constants.vsProjectKindUnmodeled)
                {
                    projects.Add(project);
                }
            }

            return projects;
        }

        // Gets all projects within a solution folder (recursive)
        public static List<Project> GetSolutionFolderProjects(Project project)
        {
            var projects = new List<Project>();

            for (var i = 1; i <= project.ProjectItems.Count; i++)
            {
                var subProject = project.ProjectItems.Item(i)?.SubProject;

                if (subProject == null) continue;

                if (SolutionItemTypes.Contains(subProject.Kind))
                {
                    projects.AddRange(GetSolutionFolderProjects(subProject));
                }
                else if (subProject.Kind != Constants.vsProjectKindUnmodeled)
                {
                    projects.Add(subProject);
                }
            }

            return projects;
        }

        // Gets a specific project in the solution
        public static Project GetProject(Solution2 solution, string name, string kind)
        {
            return GetProjects(solution).FirstOrDefault(x => x.Name == name && x.Kind == kind);
        }

        // Gets the folders in a solution
        public static List<Project> GetSolutionFolders(Solution2 solution)
        {
            var folders = new List<Project>();

            for (var i = 1; i <= solution.Projects.Count; i++)
            {
                var project = solution.Projects.Item(i);

                if (SolutionItemTypes.Contains(project.Kind))
                {
                    folders.Add(project);
                }
            }

            return folders;
        }

        // Gets the folders in a project
        public static List<ProjectItem> GetProjectFolders(Project project)
        {
            var folders = new List<ProjectItem>();

            for (var i = 1; i <= project.ProjectItems.Count; i++)
            {
                var projectItem = project.ProjectItems.Item(i);

                if (SolutionItemTypes.Contains(projectItem.Kind))
                {
                    folders.Add(projectItem);
                }
            }

            return folders;
        }

        // Add a sub solution folder
        public static void AddSolutionFolder(Project project, string name)
        {
            var solutionFolder = project.Object as SolutionFolder;

            if (solutionFolder == null) return;

            if(GetProjectFolders(project).All(x => x.Name != name))
                solutionFolder.AddSolutionFolder(name);
        }

        // Get a project's item
        public static ProjectItem GetProjectItem(Project project, string itemName)
        {
            for (var i = 1; i <= project.ProjectItems.Count; i++)
            {
                var item = project.ProjectItems.Item(i);

                if (item.Name != itemName) continue;

                return item;
            }

            return null;
        }

        // Delete a project's item
        public static void DeleteProjectItem(Project project, string itemName)
        {
            for (var i = 1; i <= project.ProjectItems.Count; i++)
            {
                var item = project.ProjectItems.Item(i);

                if (item.Name != itemName) continue;

                item.Delete();

                break;
            }
        }
    }
}
