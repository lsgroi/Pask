using System.Collections.Generic;
using System.IO;
using System.Linq;
using EnvDTE;
using EnvDTE80;
using Microsoft.VisualStudio.TemplateWizard;

namespace Pask.Extension.ProjectTemplateWizard
{
    /// Defines the logic for the template wizard extension.
    public class WizardImplementation : IWizard
    {
        private Solution2 _solution;
        private string _projectName;

        /// Runs custom wizard logic at the beginning of a template wizard run.
        /// <param name="automationObject">The automation object being used by the template wizard.</param>
        /// <param name="replacementsDictionary">The list of standard parameters to be replaced.</param>
        /// <param name="runKind">A <see cref="T:Microsoft.VisualStudio.TemplateWizard.WizardRunKind" /> indicating the type of wizard run.</param>
        /// <param name="customParams">The custom parameters with which to perform parameter replacement in the project.</param>
        public void RunStarted(object automationObject, Dictionary<string, string> replacementsDictionary, WizardRunKind runKind, object[] customParams)
        {
            _solution = (automationObject as _DTE).Solution as Solution2;
            _projectName = replacementsDictionary["$safeprojectname$"];
        }

        /// Runs custom wizard logic when a project has finished generating
        /// <param name="project">The project that finished generating.</param>
        public void ProjectFinishedGenerating(Project project)
        {
        }

        /// Runs custom wizard logic when the wizard has completed all tasks.
        public void RunFinished()
        {
            var solutionDir = Path.GetDirectoryName(_solution.FullName);
            var project = EnvDteExtensions.GetProject(_solution, _projectName, EnvDteExtensions.CSharpType);
            var projectDir = Path.GetDirectoryName(project.FullName);

            // Add '.build' solution folder and directory
            var buildSolutionFolder = EnvDteExtensions.GetSolutionFolders(_solution).FirstOrDefault(x => x.Name == ".build")
                                      ?? _solution.AddSolutionFolder(".build");
            var buildDir = FileSystemExtensions.CreateDirectory(Path.Combine(solutionDir, ".build"));

            // Add 'tasks' solution folder and directory
            if (EnvDteExtensions.GetProjectFolders(buildSolutionFolder).All(x => x.Name != "tasks"))
                EnvDteExtensions.AddSolutionFolder(buildSolutionFolder, "tasks");
            FileSystemExtensions.CreateDirectory(Path.Combine(buildDir, "tasks"));
            
            // Add 'scripts' solution folder and directory
            if (EnvDteExtensions.GetProjectFolders(buildSolutionFolder).All(x => x.Name != "scripts"))
                EnvDteExtensions.AddSolutionFolder(buildSolutionFolder, "scripts");
            var scriptsDir = FileSystemExtensions.CreateDirectory(Path.Combine(buildDir, "scripts"));

            // Initialize the solution copying the files
            {
                var initDir = Path.Combine(projectDir, "init");

                // Override Pask build runner and script
                File.Copy(Path.Combine(initDir, "Pask.ps1"), Path.Combine(solutionDir, "Pask.ps1"), true);
                File.Copy(Path.Combine(initDir, ".build", "scripts", "Pask.ps1"), Path.Combine(scriptsDir, "Pask.ps1"), true);

                // Copy the remaining files
                if (!File.Exists(Path.Combine(solutionDir, ".gitignore"))) File.Copy(Path.Combine(initDir, ".gitignore"), Path.Combine(solutionDir, ".gitignore"));
                if (!File.Exists(Path.Combine(solutionDir, "go.bat"))) File.Copy(Path.Combine(initDir, "go.bat"), Path.Combine(solutionDir, "go.bat"));
                if (!File.Exists(Path.Combine(solutionDir, "NuGet.Config"))) File.Copy(Path.Combine(initDir, "NuGet.Config"), Path.Combine(solutionDir, "NuGet.Config"));
                if (!File.Exists(Path.Combine(solutionDir, "README.md"))) File.Copy(Path.Combine(initDir, "README.md"), Path.Combine(solutionDir, "README.md"));
                if (!File.Exists(Path.Combine(buildDir, ".gitignore"))) File.Copy(Path.Combine(initDir, ".build", ".gitignore"), Path.Combine(buildDir, ".gitignore"));
                if (!File.Exists(Path.Combine(buildDir, "build.ps1"))) File.Copy(Path.Combine(initDir, ".build", "build.ps1"), Path.Combine(buildDir, "build.ps1"));

                // Add build script to the solution
                if(EnvDteExtensions.GetProjectItem(buildSolutionFolder, "build.ps1") == null)
                    buildSolutionFolder.ProjectItems.AddFromFile(Path.Combine(solutionDir, ".build", "build.ps1"));
            }

            // Delete init directory
            Directory.Delete(Path.Combine(projectDir, "init"), true);
            EnvDteExtensions.DeleteProjectItem(project, "init");
        }

        /// Runs custom wizard logic before opening an item in the template.
        /// <param name="projectItem">The project item that will be opened.</param>
        public void BeforeOpeningFile(ProjectItem projectItem)
        {
        }

        /// Indicates whether the specified project item should be added to the project.
        /// <returns>true if the project item should be added to the project; otherwise, false.</returns>
        /// <param name="filePath">The path to the project item.</param>
        public bool ShouldAddProjectItem(string filePath)
        {
            return true;
        }

        /// Runs custom wizard logic when a project item has finished generating.
        /// <param name="projectItem">The project item that finished generating.</param>
        public void ProjectItemFinishedGenerating(ProjectItem projectItem)
        {
        }
    }
}
