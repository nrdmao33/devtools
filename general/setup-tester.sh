#!/bin/bash
#
# Bootstrap a tester machine with passwordless SSH access, devtools, and
# tsdb_stest so it is ready for board/system testing.
#
# Each step is idempotent and safe to re-run against a machine that is
# already partially set up.

set -e

IAM=$(basename "$0")
DEVTOOLS_REPO="git@github.com:nrdmao33/devtools.git"
TSDB_STEST_REPO="git@github.com:sonatus/tsdb_stest.git"
KEY_PRIV=~/.ssh/id_ed25519
KEY_PUB=~/.ssh/id_ed25519.pub
LOCAL_DBC_CONVERT=~/work/dev/static_build/install/bin/snt_dbc_convert

USAGE="
usage: $IAM <tester-host>

Bootstrap a tester machine (e.g. mst-tester-107.ie.sonatus.com):
  1. Set up passwordless SSH access, if not already working, by copying
     ~/.ssh/id_ed25519{,.pub} to the target and adding the public key to
     its authorized_keys. You will be prompted for your login password once.
  2. Clone and install ~/src/devtools ($DEVTOOLS_REPO).
  3. Clone ~/work/dev/tsdb_stest ($TSDB_STEST_REPO).
  4. Copy the locally built snt_dbc_convert binary to
     ~/work/dev/static_build/install/bin/ on the target, so setup_board.sh
     does not need to compile static_build on the tester.
"

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ -z "$1" ]
then
    echo "$USAGE"
    [ -z "$1" ] && exit 1 || exit 0
fi

TARGET="$1"

MUX_PATH="/tmp/ssh-mux-setup-tester-$$"
MUX_OPTS=(-o ControlMaster=auto -o ControlPath="$MUX_PATH" -o ControlPersist=120)
cleanup() { ssh -O exit "${MUX_OPTS[@]}" "$TARGET" >/dev/null 2>&1; }
trap cleanup EXIT

echo "==> Checking passwordless access to $TARGET"
if ssh -o BatchMode=yes -o ConnectTimeout=5 "$TARGET" true 2>/dev/null
then
    echo "    already set up"
else
    echo "==> Setting up passwordless access (you will be prompted for your password once)"
    [ -f "$KEY_PRIV" ] && [ -f "$KEY_PUB" ] || {
        echo "$IAM: $KEY_PRIV / $KEY_PUB not found" >&2
        exit 1
    }

    ssh "${MUX_OPTS[@]}" "$TARGET" 'mkdir -p -m 700 ~/.ssh'
    scp "${MUX_OPTS[@]}" "$KEY_PRIV" "$KEY_PUB" "$TARGET:.ssh/"
    ssh "${MUX_OPTS[@]}" "$TARGET" '
        set -e
        chmod 600 ~/.ssh/id_ed25519
        chmod 644 ~/.ssh/id_ed25519.pub
        touch ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
        grep -qxF "$(cat ~/.ssh/id_ed25519.pub)" ~/.ssh/authorized_keys ||
            cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
    '

    if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "$TARGET" true 2>/dev/null
    then
        echo "$IAM: passwordless access still not working after setup" >&2
        exit 1
    fi
    echo "    passwordless access confirmed"
fi

SSH="ssh -o BatchMode=yes"

echo "==> Trusting github.com host key on $TARGET"
$SSH "$TARGET" '
    mkdir -p -m 700 ~/.ssh
    touch ~/.ssh/known_hosts
    grep -q "^github.com " ~/.ssh/known_hosts 2>/dev/null ||
        ssh-keyscan -H github.com >> ~/.ssh/known_hosts 2>/dev/null
'

echo "==> devtools"
$SSH "$TARGET" "
    mkdir -p ~/src
    [ -d ~/src/devtools ] || git clone $DEVTOOLS_REPO ~/src/devtools
    cd ~/src/devtools && make && make install
"

echo "==> tsdb_stest"
$SSH "$TARGET" "
    mkdir -p ~/work/dev
    [ -d ~/work/dev/tsdb_stest ] || git clone $TSDB_STEST_REPO ~/work/dev/tsdb_stest
"

echo "==> static_build/install/bin/snt_dbc_convert"
if [ ! -e "$LOCAL_DBC_CONVERT" ]
then
    echo "$IAM: local $LOCAL_DBC_CONVERT not found, skipping" >&2
else
    # bazel-built binaries are typically mode 555 (no write bit), so scp cannot
    # overwrite a previously copied file in place -- remove it first.
    $SSH "$TARGET" '
        mkdir -p ~/work/dev/static_build/install/bin
        rm -f ~/work/dev/static_build/install/bin/snt_dbc_convert
    '
    scp -o BatchMode=yes "$LOCAL_DBC_CONVERT" "$TARGET:work/dev/static_build/install/bin/snt_dbc_convert"
    $SSH "$TARGET" 'chmod +x ~/work/dev/static_build/install/bin/snt_dbc_convert'
fi

echo "==> Done: $TARGET is set up"
