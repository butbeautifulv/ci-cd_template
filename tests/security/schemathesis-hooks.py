# Optional Schemathesis hooks — copy path via SCHEMATHESIS_HOOKS or default location.
# See: https://schemathesis.readthedocs.io/en/stable/guides/extending/

# Example: add auth header for preprod
# @schemathesis.auth()
# def auth(context, case):
#     case.headers = case.headers or {}
#     case.headers["Authorization"] = f"Bearer {os.environ['PREPROD_API_TOKEN']}"
