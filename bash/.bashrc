# Reauth CodeArtifact credentials for spring
reauth_spring_aws() {
  # Check if token is missing OR older than 660 minutes (11 hours)
  # The '-n' check ensures the find command actually returned a result
  if [[ ! -f ~/.aws_codeartifact_token ]] || [[ -n $(find ~/.aws_codeartifact_token -mmin +660 2>/dev/null) ]]; then
    echo "AWS Token expired or missing. Refreshing..."
    aws codeartifact get-authorization-token \
      --domain ktechartifacts --domain-owner 356635979126 --region us-east-2 \
      --query authorizationToken --output text > ~/.aws_codeartifact_token
  fi

  # 3. Export for the current process
  echo "exporting code artifact token"
  export CODEARTIFACT_AUTH_TOKEN=$(cat ~/.aws_codeartifact_token)
}

# Maven wrapper for Spring AWS auth
mvn() {
  # Only act if we are in the spring work directory
  if [[ "$PWD" == "$HOME/work/spring"* ]]; then
    reauth_spring_aws
  fi

  # 4. Run the actual Maven command
  command mvn "$@"
}

# Intellij wrapper for Spring AWS auth
idea() {
  # Only act if we are in the spring work directory
  if [[ "$PWD" == "$HOME/work/spring"* ]]; then
    reauth_spring_aws
  fi

  # 4. Run the actual Maven command
  command idea "$@"
}
