#
# functions for colored output
#
if [ "$COLOR" = "false" ]; then
  NOCOLOR='\033[0m'
  GREEN=$NOCOLOR
  CYAN=$NOCOLOR
  YELLOW=$NOCOLOR
  MAGENTA=$NOCOLOR
  RED=$NOCOLOR
else 
  NOCOLOR='\033[0m'
  GREEN='\033[0;32m'
  CYAN='\033[0;36m'
  YELLOW='\033[1;32m'
  MAGENTA='\033[0;35m'
  RED='\033[0;31m'
fi

function log.debug   { [ $DEBUG == "true" ] && echo -e "${NOCOLOR}$1"; }
function log.info    { echo -e "${GREEN}$1${NOCOLOR}"; }
function log.notice  { echo -e "${CYAN}$1${NOCOLOR}"; }
function log.warning { echo -e "${YELLOW}$1${NOCOLOR}"; }
function log.error   { echo -e "${MAGENTA}$1${NOCOLOR}"; }
function log.fatal   { echo -e "${RED}$1${NOCOLOR}"; }
function log.cyan    { echo -e "${CYAN}$1${NOCOLOR}"; }
function log.green   { echo -e "${GREEN}$1${NOCOLOR}"; }
function log.magenta { echo -e "${MAGENTA}$1${NOCOLOR}"; }
function log.red     { echo -e "${RED}$1${NOCOLOR}"; }
function log.yellow  { echo -e "${YELLOW}$1${NOCOLOR}"; }
