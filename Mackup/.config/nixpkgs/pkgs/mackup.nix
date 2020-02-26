{ buildPythonApplication, fetchPypi, six, docopt }:

buildPythonApplication rec {
  pname = "mackup";
  version = "0.8.27";

  src = fetchPypi {
    inherit pname version;
    sha256 = "10clg9bqij08ha93jk85fhgx1jlm6j96i1cz53yfjl7rls7nk682";
  };

  buildInputs = [ six docopt ];
};
