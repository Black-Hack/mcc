### Gitblob

Gitblob is a Lua Computercraft program designed to facilitate directory syncing across multiple computers on the same network.

### How It Works

1. **Hosting a Directory**:

   Run the command:
   ```
   gitblob watch fullDirectoryPath
   ```
   This will host the specified directory online.

2. **Syncing Content**:

   Run the command:
   ```
   gitblob sync server_id FullTargetDirectoryPath
   ```
   This will update the content of the target directory to match that of the server's hosted files.

3. **Listing Online Servers**:

   Run the command:
   ```
   gitblob lookup
   ```
   This will list online servers' IDs.

By following these simple commands, you can easily sync directories across multiple computers on the same network using Gitblob.