# Create a 1-of-4 P2SH multisig address from the public keys in the four inputs of this tx:
#   `37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517`

#!/bin/bash
set -e

raw_tx=$(bitcoin-cli getrawtransaction 37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517 true)

keys=()

for i in $(echo "$raw_tx" | jq -r '.vin | keys[]'); do
  pubkey=$(echo "$raw_tx" | jq -r ".vin[$i].txinwitness[-1]")
  
  # Verifique se é uma chave pública válida
  if [[ $pubkey =~ ^(02|03)[0-9a-fA-F]{64}$ ]]; then
    keys+=("$pubkey")
  fi
done

if [ ${#keys[@]} -lt 4 ]; then
  echo "Erro: Menos de 4 chaves públicas foram encontradas." >&2
  exit 1
fi

address=$(bitcoin-cli createmultisig 1 "$(printf '%s\n' "${keys[@]}" | jq -R -s -c 'split("\n")[:-1]')" | jq -r '.address')

echo $address

