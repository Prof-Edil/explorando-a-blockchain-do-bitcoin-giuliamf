# Create a 1-of-4 P2SH multisig address from the public keys in the four inputs of this tx:
#   `37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517`

#!/bin/bash
#!/bin/bash
raw_tx=$(bitcoin-cli getrawtransaction 37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517 true)

keys=()

for i in $(echo "$raw_tx" | jq -r '.vin | keys[]'); do
  key=$(echo "$raw_tx" | jq -r ".vin[$i].txinwitness[-1]")

  if [[ $key =~ ^(02|03)[0-9a-fA-F]{64}$ ]]; then
    keys+=("$key")
  fi
done

if [ ${#keys[@]} -lt 4 ]; then
  echo "Erro: Menos de 4 chaves públicas foram encontradas."
  exit 1
fi

keys_json=$(printf '%s\n' "${keys[@]}" | jq -R -s -c 'split("\n")[:-1]')

multisig=$(bitcoin-cli createmultisig 1 "$keys_json")
echo $multisig
