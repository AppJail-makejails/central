# central: template engine for appjail-makejails

central is a collection of small scripts designed to create and update repositories for this organization in a centralized manner. The goal is to reduce manual effort and facilitate scalability (even as more Makejails are added) as well as to streamline and simplify the transition from AppJail images to OCI images.

## How to use this repository

Each “project” is a subdirectory within `projects/`, and in the project directory, there are small files called "keywords." Each of these has a specific meaning for the `scripts/update.sh` script, but the final result will be a `README.md` file, a `.daemonless/config.yaml` file, and a `.github/workflows/build.yaml` file in the project’s working directory.

### Keywords

* `name` (optional): Project name. If not defined, the directory name is used.
* `descr` (mandatory): Description. If there is an entry on Wikipedia, use it; otherwise, use the official one.
* `www` (optional): Home page. If there is an entry on Wikipedia, use it; otherwise, use the official one.
* `logo` (optional): Link to the logo.
* `howto` (mandatory): A detailed explanation of how to use the Makejail. Use markdown.
* `arguments/{stage}/{name}/` (optional): Arguments used at each different stages. Name in lowercase.
* `environment/{stage}/{name}/` (optional): Environment variables used at each different stages. Name in lowercase.
* `volumes/{name}/` (optional): Volumes used by this Makejail.
* `notes` (optional): Notes and extra information about this Makejail. Use markdown.
* `sub/{name}` (optional): Substitution list. Name in uppercase.
* `daemonless.yaml` (optional): dbuild configuration to build OCI images.

#### Keywords: {arguments,environment}/{stage}/{name}/

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
