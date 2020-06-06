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
         kubectl get pods -o wide "$@"
     }

     if [[ -x "$(command -v fzf)" ]]; then
         # Prints, run and stores command to the history
         _run_cmd() {
             local orig_cmd="$1"
             shift
             local cmd=("$@")

             history -s "${orig_cmd}"
             history -s "${cmd[*]}"
             echo "${cmd[*]}"
             ${cmd[*]}
         }

         # shellcheck disable=SC2120
         kp() {
             kubectl get pods --no-headers -o wide "$@" | fzf | cut -d ' ' -f1
         }

         # shellcheck disable=SC2120
         kpa() {
             kubectl get pods --no-headers -o wide -A "$@" | fzf | tr -s ' ' | cut -d ' ' -f-2
         }

         kd() {
             local pod
             pod="$(kp)"

             local cmd=(kubectl describe pod "$@" "${pod}")
             _run_cmd "${FUNCNAME[0]} ${*}" "${cmd[*]}"
         }

         kda() {
             local ns_and_pod
             ns_and_pod="$(kpa)"

             local cmd=(kubectl describe pod "$@" -n "${ns_and_pod}")
             _run_cmd "${FUNCNAME[0]} ${*}" "${cmd[*]}"
         }

         kl() {
             local pod
             pod="$(kp)"

             local cmd=(kubectl logs "$@" "${pod}")
             _run_cmd "${FUNCNAME[0]} ${*}" "${cmd[*]}"
         }

         kla() {
             local ns_and_pod
             ns_and_pod="$(kpa)"

             local cmd=(kubectl logs "$@" -n "${ns_and_pod}")
             _run_cmd "${FUNCNAME[0]} ${*}" "${cmd[*]}"
         }

         kx() {
             local pod
             pod="$(kp)"
	     local pod_cmd=("${@:-bash}")

             local cmd=(kubectl exec -it "${pod}" -- "${pod_cmd[*]}")
             _run_cmd "${FUNCNAME[0]} ${*}" "${cmd[*]}"
         }

         kxa() {
             local ns_and_pod
             ns_and_pod="$(kpa)"
	     local pod_cmd=("${@:-bash}")

             local cmd=(kubectl exec -it -n "${ns_and_pod}" -- "${pod_cmd[*]}")
             _run_cmd "${FUNCNAME[0]} ${*}" "${cmd[*]}"
         }
     fi
fi

if [[ -x "$(command -v helm)" ]]; then
    alias h='helm'
    source <(helm completion bash)
    complete -F __start_helm h
fi
