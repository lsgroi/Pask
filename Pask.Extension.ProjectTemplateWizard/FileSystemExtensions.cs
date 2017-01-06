using System.IO;

namespace Pask.Extension.ProjectTemplateWizard
{
    public static class FileSystemExtensions
    {
        public static string CreateDirectory(string fullName)
        {
            return Directory.Exists(fullName) ? fullName : Directory.CreateDirectory(fullName).FullName;
        }
    }
}