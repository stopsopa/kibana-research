
set -e;

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )";

source "$ROOT/bash/colours.sh"

source "$ROOT/.env";

if [ "" = "" ]; then

  { red "\n\n   first argumet is not specified\n\n"; } 2>&3

  echo available fixtures sets are:

find fixtures -type d | awk '
BEGIN {
  FS="/"
}
{ print $2 }
' | grep -v "^$" | sed -r "s/(^.*$)/\n    \/bin\/bash $0 \1/g"

  echo ""

  exit 1
fi










