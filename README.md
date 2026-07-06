# central: template engine for appjail-makejails

central is a collection of small scripts designed to create and update repositories for this organization in a centralized manner. The goal is to reduce manual effort and facilitate scalability (even as more Makejails are added) as well as to streamline and simplify the transition from AppJail images to OCI images.

## How to use this repository

Each “project” is a subdirectory within `projects/`, and in the project directory, there are small files called "keywords." Each of these has a specific meaning for the `scripts/update.sh` script, but the final result will be a `README.md` file, a `.daemonless/config.yaml` file, and a `.github/workflows/build.yaml` file in the project’s working directory.

Whether you just want to update it or create a new one, the repository must already exist in this organization before you create the project. Once this requirement is met, use `./scripts/fetch.sh <project>` to clone the repository, where `<project>` is the name of the subdirectory, which must match the name of the repository. If no project is specified, this script will clone all repositories based on the subdirectories in `projects/`.

Once the repository has been cloned, it will be located in `wrkdir/`. This will be the working directory for managing repositories, so it must have write permissions. Once that’s done, you can create a project in `projects/`, if you haven’t already, and then run `./scripts/update.sh <project>`. Finally, this will create a `README.md` file, a `.daemonless/config.yaml` file, and a `.github/workflows/build.yaml` file, overwriting any existing files.

A substitution list is used to replace values. `templates/sub/` serves as a centralized location for parameters shared by all projects. Each project has its own substitution list, which takes precedence over all others. For example, if you have a parameter named `PARAM1` in one of the files mentioned above, you can specify this parameter as `%%PARAM1%%` within that file, and the value of this parameter will be used as the final result. There is a special parameter called `%%NAME%%` that is replaced with the project name, but only `.github/workflows/build.yaml` uses it.

### Keywords

* `name` (optional): Project name. If not defined, the directory name is used. 
* `alias` (optional): An alternative name used by operations (such as the generation of the `*_from` and `*_tag` arguments) that cannot use all characters. If not defined, the directory name is used.
* `descr` (mandatory): Description. If there is an entry on Wikipedia, use it; otherwise, use the official one.
* `www` (optional): Home page. If there is an entry on Wikipedia, use it; otherwise, use the official one.
* `logo` (optional): Link to the logo.
* `howto` (mandatory): A detailed explanation of how to use the Makejail. Use markdown.
* `arguments/{stage}/{name}/` (optional): Arguments used at each different stages. Name in lowercase.
* `environment/{stage}/{name}/` (optional): Environment variables used at each different stages. Name in lowercase.
* `oci/environment/{name}/` (optional): Environment variables used by the OCI image.
* `oc/empty_env` (optional): An empty file that, when present, don't add default environment variables.
* `volumes/{name}/` (optional): Volumes used by this Makejail.
* `notes` (optional): Notes and extra information about this Makejail. Use markdown.
* `sub/{name}` (optional): Substitution list. Name in uppercase.
* `daemonless.yaml` (optional): dbuild configuration to build OCI images.

#### Keywords: {oci/environment,{arguments,environment}/{stage}}/{name}/

* `name` (mandatory): Parameter name.
* `mandatory` (optional): An empty file that, when present, makes the parameter required. This has no effect if `default` is set.
* `default` (optional): Default value for this parameter.
* `descr` (mandatory): Parameter description.

#### Keywords: volumes/{name}/

* `name` (mandatory): Volume name.
* `owner` (default: `${puid}`): volume's user ID.
* `group` (default: `${pgid}`): volume's group ID.
* `perm` (optional): volume's file mode.
* `type` (optional): File system type.
* `mountpoint` (optional): Path within the jail to mount the volume.
