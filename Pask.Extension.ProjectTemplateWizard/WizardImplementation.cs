using System.Collections.Generic;
using System.IO;
using System.Linq;
using EnvDTE;
using EnvDTE80;
using Microsoft.VisualStudio.ComponentModelHost;
using Microsoft.VisualStudio.TemplateWizard;
using Microsoft.VisualStudio.Shell;
using NuGet.VisualStudio;

namespace Pask.Extension.ProjectTemplateWizard
{
    /// Defines the logic for the template wizard extension.
    public class WizardImplementation : IWizard
    {
        private DTE _dte;
        private Solution2 _solution;
        private string _projectName;

        /// Runs custom wizard logic at the beginning of a template wizard run.
        /// <param name="automationObject">The automation object being used by the template wizard.</param>
        /// <param name="replacementsDictionary">The list of standard parameters to be replaced.</param>
        /// <param name="runKind">A <see cref="T:Microsoft.VisualStudio.TemplateWizard.WizardRunKind" /> indicating the type of wizard run.</param>
        /// <param name="customParams">The custom parameters with which to perform parameter replacement in the project.</param>
        public void RunStarted(object automationObject, Dictionary<string, string> replacementsDictionary, WizardRunKind runKind, object[] customParams)
        {
            _dte = automationObject as DTE;
            _solution = _dte.Solution as Solution2;
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

            // Add solution items
            var initDir = Path.Combine(projectDir, "init");
            var buildDir = Directory.Exists(Path.Combine(solutionDir, ".build")) ? Path.Combine(solutionDir, ".build") : FileSystemExtensions.CreateDirectory(Path.Combine(solutionDir, ".build"));
            var solutionItemsFolder = EnvDteExtensions.GetSolutionFolders(_solution).FirstOrDefault(x => x.Name == "Solution Items") ?? _solution.AddSolutionFolder("Solution Items");
            var nugetFolder = EnvDteExtensions.GetSolutionFolders(_solution).FirstOrDefault(x => x.Name == ".nuget") ?? _solution.AddSolutionFolder(".nuget");
            if (!File.Exists(Path.Combine(solutionDir, ".gitignore"))) File.Copy(Path.Combine(initDir, ".gitignore"), Path.Combine(solutionDir, ".gitignore"));
            if (!File.Exists(Path.Combine(solutionDir, "NuGet.Config"))) File.Copy(Path.Combine(initDir, "NuGet.Config"), Path.Combine(solutionDir, "NuGet.Config"));
            if (EnvDteExtensions.GetProjectItem(nugetFolder, "Nuget.config") == null) solutionItemsFolder.ProjectItems.AddFromFile(Path.Combine(solutionDir, "NuGet.Config"));
            if (!File.Exists(Path.Combine(solutionDir, "README.md"))) File.Copy(Path.Combine(initDir, "README.md"), Path.Combine(solutionDir, "README.md"));
            if (EnvDteExtensions.GetProjectItem(solutionItemsFolder, "README.md") == null) solutionItemsFolder.ProjectItems.AddFromFile(Path.Combine(solutionDir, "README.md"));
            if (!File.Exists(Path.Combine(buildDir, "build.ps1"))) File.Copy(Path.Combine(initDir, ".build", "build.ps1"), Path.Combine(buildDir, "build.ps1"));
            
            // Delete init directory
            EnvDteExtensions.DeleteProjectItem(project, "init");

            // Install Pask
            var componentModel = (IComponentModel) Package.GetGlobalService(typeof(SComponentModel));
            var installerServices = componentModel.GetService<IVsPackageInstallerServices>();
            if (installerServices.IsPackageInstalled(project, "Pask")) return;
            var installer = componentModel.GetService<IVsPackageInstaller>();
            installer.InstallPackage("https://api.nuget.org/v3/index.json", project, "Pask", (System.Version) null, false);

            _dte.Documents.CloseAll();
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
