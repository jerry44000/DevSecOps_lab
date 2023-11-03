package main

# Do Not store secrets in ENV variables
secrets_env = [
    "passwd",
    "password",
    "pass",
    "secret",
    "key",
    "access",
    "api_key",
    "apikey",
    "token",
    "tkn"
]

deny[msg] {    
    some i
    input[i].Cmd == "env"
    val := input[i].Value
    some j
    contains(lower(val), secrets_env[j]) # Assume val is a string, not a list
    msg = sprintf("Line %d: Potential secret in ENV key found: %s", [i+1, val]) # Adjust i to human-readable line number
}

# Only use trusted base images
#deny[msg] {
#    some i
#    input[i].Cmd == "from"
#    val := split(input[i].Value[0], "/")
#    count(val) > 1
#    msg = sprintf("Line %d: use a trusted base image", [i+1])
#}

# Do not use 'latest' tag for base images
deny[msg] {
    some i
    input[i].Cmd == "from"
    val := split(input[i].Value[0], ":")
    val[1] == "latest" # Assuming Value[0] is the full image name including the tag
    msg = sprintf("Line %d: do not use 'latest' tag for base images", [i+1])
}

# Avoid curl bashing
deny[msg] {
    some i
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    re_match("(curl|wget)[^|^>]*[|>]", lower(val))
    msg = sprintf("Line %d: Avoid curl bashing", [i+1])
}

# Do not upgrade your system packages
warn[msg] {
    some i
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    re_match(".*?(apk|yum|dnf|apt|pip).+?(install|[dist-|check-|group]?up[grade|date]).*", lower(val))
    msg = sprintf("Line: %d: Do not upgrade your system packages: %s", [i+1, val])
}


# Do not use ADD if possible
deny[msg] {
    some i
    input[i].Cmd == "add"
    msg = sprintf("Line %d: Use COPY instead of ADD", [i+1])
}

# Any user...
any_user {
    some i
    input[i].Cmd == "user"
 }

deny[msg] {
    not any_user
    msg = "Do not run as root, use USER instead"
}

# ... but do not root
forbidden_users = [
    "root",
    "toor",
    "0"
]

deny[msg] {
    some i
    input[i].Cmd == "user"
    lastuser := input[i].Value
    some j
    lower(lastuser) == forbidden_users[j] # Assuming Value is the username
    msg = sprintf("Line %d: Last USER directive (USER %s) is forbidden", [i+1, lastuser])
}

# Do not sudo
deny[msg] {
    some i
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    contains(lower(val), "sudo")
    msg = sprintf("Line %d: Do not use 'sudo' command", [i+1])
}

# Use multi-stage builds
default multi_stage = false
multi_stage = true {
    some i
    input[i].Cmd == "copy"
    val := concat(" ", input[i].Flags)
    contains(lower(val), "--from=")
}
deny[msg] {
    not multi_stage
    msg = "You COPY, but do not appear to use multi-stage builds..."
}
