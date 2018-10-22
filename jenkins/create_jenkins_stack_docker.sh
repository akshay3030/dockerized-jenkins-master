#! /bin/bash

OPTN=${1}
NUMOPTNMX=2
CMPSFLDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GREP=$(which grep)
UNME=$(which uname)

printUsage() {

  echo " Usage: $(basename $0) < up|ps|logs|down >"
  exit 0

}

if "${UNME}" -v | "${GREP}" -i darwin 2>&1 > /dev/null
 then
    OS='darwin'
 else
    OS='linux'
fi
echo "Operation System is --> ${OS}"

# change to always run for bind mount vs named volume(stateful volume(ebs volume) with mount to /var/jenkins_home)
OS='darwin'
CMPSEFILE="jenkins_stack_${OS}.yml"


if [[ $# -gt ${NUMOPTNMX} ]]
then
  printUsage
fi

if [[ "${OPTN}" != "up" ]] && \
   [[ "${OPTN}" != "ps" ]] && \
   [[ "${OPTN}" != "logs" ]] && \
   [[ "${OPTN}" != "down" ]]
then
  printUsage
else
  if [[ "${OPTN}" = "up" ]]
  then
    docker-compose -f "${CMPSFLDIR}/${CMPSEFILE}" "${OPTN}" -d
  else
    docker-compose -f "${CMPSFLDIR}/${CMPSEFILE}" "${OPTN}"
  fi
fi

#docker exec -i -u root scripts_jenkins_1 chown jenkins /var/run/docker.sock || true
