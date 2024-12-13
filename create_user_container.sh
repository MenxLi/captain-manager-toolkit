# docker run -t -d \
#     -v /data/lijiayu:/remote-data/lijiayu \
#     -v /data/share:/remote-data/share:ro \
#     -p 15002:22 \
#     --gpus 'all,"capabilities=compute,utility,graphics"' \
#     --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
#     --name test_for_cuda_error ubuntu2204-cu121-user-env:latest \
#     /opt/captain/entrypoint.sh lijiayu 3001 6MDTqYO7yrHJ2Mxa "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAT0Vvnlpb8F4J9t+vLNAvpo7/tFP7gnsTnI5F/3LfNohRw53J05ifU8+ESUwtlq9HyOLIxotX2bS7IWkY4fJNon3KclC04vAgLzs4rtk6yhK1ECk8D1DRYxVdoOx4jOnUHxLRLXPg7LEoaZ4PsHjKk7gvF5qBf7VpgVNIY5wQ7hDLgAWMbrlLOhsf2bVcpoeg2Mu8wRXh6TDvblJ+1Z4bWnI9CWaeUnusfTarU254JQVaj8JnZK7obPO8PAUjOjhiCqzVg7YFvj0UF+afPHzA0gwbn9W9lH9DKGiU89w4KR6KDOcq7TDJSVs2YyxgnMKwaBdidHaoBRV0iJLercjj admin@WD-01"

#     # --storage-opt size=20G \
# chown -R 3001:3001 /data/lijiayu



# docker run -t -d \
#     -v /data/liuzujing:/remote-data/liuzujing \
#     -v /data/share:/remote-data/share:ro \
#     -p 15003:22 \
#     --gpus 'all,"capabilities=compute,utility,graphics"' \
#     --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
#     --name liuzujing ubuntu2204-cu121-user-env:latest \
#     /opt/captain/entrypoint.sh liuzujing 3002 "mq888*oten" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCyr28jW1d8CdBTo5W/j62SOWxHU2Uv4zWH/5RGPCHRN8roSKcK4bydb6yBvtLXxIHoxfHcxLbTq7ilJFfeRCneM8W43rrECLkT5TZ2Gmm+t+fDW5nYFDHCebPi8DG1g21ab0r/JztiPLHDinTj4mw/391RKQbfKDmY3a7VTc+A0dTk5Z/Z6YTnbO1/dunlWvT9uoCi5v6e9vFbm/VQOvlipl9h+r9P8GXxlysCZvG9RWIZnvYPSGFzl2DW8y5ZiPJi0qe7+M4RRLRUaSSlIWlknlRQq+7rCqXzTBeBTtX6FMvETEHK/TPb/E//xvxYnOdcb3NFd4xXQDoiIgRg1+qrfdIX8D8nYnvT1N2+w6FAVwCj2g5NM6o5c9q2tDQ4UP0tI2nY2Q/grlWXs5JgbiIXwFsk679PuguU9xNpIbE6OEnqo2rDAkc800yXCJIiUZ506Lt9tpuA5ryC5+3thH+b2HPbZpMpRrIgjyQHV3mz+xQhd6Lp0XN7AcKLBbqfqNM= liuzu@zjliu_lenovo"

#     # --storage-opt size=20G \
# chown -R 3001:3001 /data/liuzujing


# USER_NAME=pangchao
# UID=3003
# PASSWORD="CdsMZEYKNP2OjrR!"
# SSH_PORT=15004
# PUB_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDORmAjv6lL6C70l6jAdvUT2LK/8RqG1VNcAadWgcvWN6Dz5/PyEkDq77ZypjYfcbJZLAIgOIHTMUgy1ipTrxCO6VYLu1GIQlhPljTB8kKHpj++vEfABBXJYClH6Efd720gklD/3M3BRnIKhSeQYhiEjt7M9ruxNrM2++Lpt0QCgNkZACyY6+Zb47XY5JzeNMCHC0M6HBa6DMYMRWaLjsLzGpAf8ulpiJYu4jmsQpHoRHcueqShRUrS67mTtYs+60NKO/EEeOJX5WdpsAn8euUT8Uvju4inbL83UtU+xERvrhTS/EifjBbU8viBUS5bHgwnFmO1zM17waBRZaZ521roOs/e2dJSucG8/DAQ1nA1kdUuQBMtN/Zj2DwjF3hRTkzwjDwXUWTTkLlvyFfruR8bjRAjgqak9pzMVcuDC2QUkTbpCA7pQWGSrjSH6+EEKeMBtdNNhjYxR87ei4+JRQ3S377djTRzzlECtiF5kWRlvaqGiKt2Qrur3HbrXU2WE/s= 83687@LAPTOP-1QGHIJ29"

# docker run -t -d \
#     -v /data/${USER_NAME}:/remote-data/${USER_NAME} \
#     -v /data/share:/remote-data/share:ro \
#     -p ${SSH_PORT}:22 \
#     --gpus 'all,"capabilities=compute,utility,graphics"' \
#     --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
#     --name ${USER_NAME} ubuntu2204-cu121-user-env:latest \
#     /opt/captain/entrypoint.sh ${USER_NAME} ${UID} ${PASSWORD} ${PUB_KEY}

#     # --storage-opt size=20G \
# chown -R ${UID}:${UID} /data/${USER_NAME}



docker run -it \
    -v /data/pangchao:/remote-data/pangchao \
    -v /data/share:/remote-data/share:ro \
    -p 15008:22 \
    --rm \
    --memory=4g \
    --memory-swap=4g \
    --gpus 'all,"capabilities=compute,utility,graphics"' \
    --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 \
    --name test1 ubuntu2204-cu121-base:latest

    # --storage-opt size=20G \
# chown -R 3003:3003 /data/pangchao
