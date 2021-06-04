
set -e;

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )";

source "$ROOT/bash/colours.sh"

source "$ROOT/.env";

# WARNING: don't put / at the end
FIXTURESDIR="$ROOT/fixtures"

if [ "$1" = "" ]; then

  { red "\n\n   first argumet is not specified\n\n"; } 2>&3

  echo available fixtures sets are:

find "$FIXTURESDIR/" -type d -maxdepth 1 | awk '
BEGIN {
  FS="//"
}
{ print $2 }
' | grep -v "^$" | sed -r "s/(^.*$)/\n    \/bin\/bash $0 \1/g"

  echo ""

  exit 1
fi

FIXTURE="$FIXTURESDIR/$1"

if [ ! -d "$FIXTURE" ]; then

  { red "\n\n   directory '$FIXTURE' doesn't exist\n\n"; } 2>&3

  exit 1
fi

FILES="$(find "$FIXTURE" -type f -maxdepth 1 | sort)"

# unziping files
while IFS= read -r LINE; do

    EXTENSION="${LINE##*.}"
    FILENAME="${LINE%.*}"
    if [ "$FILENAME" = "" ]; then

      FILENAME="$LINE"
      EXTENSION=""
    fi
    if [ "$FILENAME" = "$LINE" ]; then

      EXTENSION=""
    fi

    if [ "$EXTENSION" = "zip" ]; then

      (
        cd "$(dirname "$LINE")"

        echo -e "\nunzipping: '$(basename "$LINE")'"

        unzip -o "$(basename "$LINE")"
      )
    fi

done <<< "$FILES"

make docs

rm -rf "docker/es"

make doc

echo wait 10 sec

sleep 10

# import files
while IFS= read -r LINE; do

    EXTENSION="${LINE##*.}"
    FILENAME="${LINE%.*}"
    if [ "$FILENAME" = "" ]; then

      FILENAME="$LINE"
      EXTENSION=""
    fi
    if [ "$FILENAME" = "$LINE" ]; then

      EXTENSION=""
    fi

    if [ "$EXTENSION" = "ndjson" ]; then

      (
        cd "$(dirname "$LINE")"

        echo -e "\nloading bulk: '$(basename "$LINE")'"

        echo "curl -H \"Content-type: application/x-ndjson\" -XPOST http://0.0.0.0:$ES_PORT/_bulk&filter_path=items --data-binary @$(basename "$LINE")"

        curl -H "Content-type: application/x-ndjson" -XPOST "http://0.0.0.0:$ES_PORT/_bulk?filter_path=items&pretty" --data-binary @$(basename "$LINE")
      )
    fi

    if [ "$EXTENSION" = "sh" ]; then

      (
        cd "$(dirname "$LINE")"

        echo -e "\nexecuting script: '$(basename "$LINE")'"

        set -x

        source "$(basename "$LINE")"

        set +x
      )
    fi

done <<< "$FILES"

#curl -H "Content-type: application/x-ndjson" -XPOST -u elastic http://0.0.0.0:$3368/_bulk --data-binary @orders.bulk.ndjson











