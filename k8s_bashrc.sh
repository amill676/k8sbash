podsForNode() {
    kubectl get pods --field-selector=spec.nodeName=$1 ${@:2}
}

deletePod() {
  if [ -z $1 ]; then
    echo 'Deletes all pods that match a given pattern'
    echo 'Usage: kudelpo <grep pattern>'
    return
  fi
  pattern="$(echo $* | sed 's/ /\\|/g')"
  pods="$(kubectl get pods | grep $pattern)"
  # Check for no pods
  if [ -z "$pods" ]; then
    echo "0 pods found"
    return
  fi
  count=`echo "$pods" | wc -l`
  echo $count pods found:
  if [ $count == 0 ]; then
    return
  fi
  echo "$pods"
  while true; do
    read -p "Are you sure you want to delete these pods? [y/n] " yn
    case $yn in
        [Yy]* ) echo "$pods" | awk '{print $1}' | xargs kubectl delete pod; break;;
        [Nn]* ) break;;
        * ) ;;
    esac
  done
}


portForward() {
  if [ "$#" -lt "2" ]; then
    echo 'Port forwards from the first pod matching a given selector'
    echo 'Usage: kupf <port> <pod selector>'
    return
  fi
  port="$1"
  podname=`kubectl get pods -o template --template="{{(index .items 0).metadata.name}}" -l "${@:2}"`
  echo "Using pod $podname"
  kubectl port-forward $podname $port
}

function switchContextOrPanic {
  kubectl config use-context "$@"
  if [ "$?" -ne 0 ]; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "Switching contexts did not work. You are still in the previous context. Beware!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  fi
}

function scaleDeploy {
  if [ -z $1 ]; then
      echo 'Usage: kusd <deployment name> <replicas>'
      return
  fi
  if [ -z $2 ]; then
      echo 'Usage: kusd <deployment name> <replicas>'
      return
  fi
  kubectl scale deploy $1 --replicas $2
}

# Aliases
alias ku=kubectl
alias kuc="switchContextOrPanic"
alias kucc="kubectl config current-context"
alias kup="kubectl get pods"
alias kug="kubectl get"
alias kugl="kubectl get -o yaml"
alias kud="kubectl describe"
alias kusd=scaleDeploy
alias kudf="kubectl delete po --force --grace-period 0"
alias kap="kubectl get pods --all-namespaces"
alias kag="kubectl get --all-namespaces"
alias kagl="kubectl get -o yaml --all-namespaces"
alias kupf=portForward
alias kudelpo=deletePod
alias kupno=podsForNode
