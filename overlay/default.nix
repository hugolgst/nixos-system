self: super:

with builtins;
let
  directory = ./pkgs;
  # Retrieve all directories/files in the directory
  entries = readDir directory;

  # Check if a specified file/directory is a directory and contains a file named default.nix
  hasDefaultFile = name:
    (getAttr name entries == "directory")
    && (hasAttr "default.nix" (readDir (directory + "/${name}")));

  # Filter all the directories containing a default.nix file
  subDirectories = filter hasDefaultFile (attrNames entries);

  # Generate the super package call
  generateCall = name: {
    inherit name;
    value = super.callPackage "${directory}/${name}" {};
  };
  # Make the calls an attribute set
  packageCalls = listToAttrs (map generateCall subDirectories);
in packageCalls