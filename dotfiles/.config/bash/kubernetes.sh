#!/bin/bash

if [[ -x "$(command -v kubectl)" ]]; then
     alias k='kubectl'
     source <(kubectl completion bash)
     complete -F __start_kubectl k

     # Add available kubeconfigs to KUBECONFIG for easy switching
     set_kubeconfig() {
         local entry
         for entry in "$HOME/.kube/configs"/*
         do
             # Get files which do not include "skip"
             if [[ -f "${entry}" ]] && [[ "${entry}" != *"skip"* ]]; then
                 kubeconfigs="${kubeconfigs}:${entry}"
             fi
         done

         # Clean first colons
         kubeconfigs=${kubeconfigs#":"}
         export KUBECONFIG="${kubeconfigs}"
     }
     set_kubeconfig

     kgp() {
         local attr
         IFS=" " read -r -a attr <<< "${@:- -o wide}"
         readonly attr
         kubectl get pods "${attr[@]}"
     }

     if [[ -x "$(command -v fzf)" ]]; then
         kp() {
             kubectl get pods --no-headers "$@" | fzf | cut -d ' ' -f1
         }

         kd() {
             local pod
             pod="$(kp -o wide)"

             local cmd=(kubectl describe pod "$@" "${pod}")
             echo "${cmd[*]}"
             history -s "${FUNCNAME[0]} ${*}"
             history -s "${cmd[*]}"
             ${cmd[*]}
         }

         kl() {
             local pod
             pod="$(kp -o wide)"

             local cmd=(kubectl logs "$@" "${pod}")
             echo "${cmd[*]}"
             history -s "${FUNCNAME[0]} ${*}"
             history -s "${cmd[*]}"
             ${cmd[*]}
         }

         kx() {
             local pod
	     pod="$(kp -o wide)"
	     local pod_cmd=("${@:-bash}")

             local cmd=(kubectl exec -it "${pod}" -- "${pod_cmd[*]}")
             echo "${cmd[*]}"
             history -s "${FUNCNAME[0]} ${*}"
             history -s "${cmd[*]}"
             ${cmd[*]}
         }
     fi
fi

if [[ -x "$(command -v helm)" ]]; then
    alias h='helm'
    source <(helm completion bash)
    complete -F __start_helm h
fi
