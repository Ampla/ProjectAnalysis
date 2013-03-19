# Ampla Project Analysis #

The Project Analysis tool generates a detailed and interactive HTML report from a project XML export.

## Getting Started ##

Follow the instructions below to generate your HTML report:

1. Export a copy of your project naming the file `AmplaProject.xml` and place it in the same folder as `AnalyseProject.cmd`.

2. Take a copy of `AuthStore.xml` and place it alongside `AmplaProject.xml`. This file will be located in the `%ProgramData%\Citect\Ampla\Projects\[YourProjectName]` folder.

3. Run `AnalyseProject.cmd` and wait for it to finish.

4. View the output by opening `index.html` located in the `Output` folder.

5. Run `Clean.cmd` to remove the existing output before running another project analysis.

## Explanations of the output ##

* `Project.Summary.html` provides a high level view of the project structure and where the reporting points are located.

* `Project.Downtime.html` provides a relationship of the downtime relationship matrix.

* `Project.Metrics.html` provides a view of the KPIs defined under the metrics reporting points and where they source their data.

* `Project.Security.html` provides a view of the Security operations, roles and where they are assigned in the project.