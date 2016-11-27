import getpass
from onepassword import Keychain

keychain_path = "/Users/mike/Dropbox/1Password/1Password.agilekeychain"
prompt = "1Password password: "


def get_password(account_name):
    my_keychain = Keychain(keychain_path)
    my_keychain.unlock(getpass.getpass(prompt=prompt))
    return my_keychain.item(account_name).password
