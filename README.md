# gittp
Expose a http api for any git repo 

## Usage

*GET /api/content/{path}/{to}/{file}* - Read the content of a file  
example:
```
    get('http://yourhost/api/content/readme.md')
    .then(response => console.log(response))

    // {
    //   "isDirectory": false,
    //   "checksum": "5F251AC5FBC3DD0C0593296E5F9281239B8B660B503DD9234EBD49648831287B",
    //   "content": "hello world!"
    // }
```

*GET /api/content/{path}/{to}/{directory}* - Read the content of a directory  
example:
```
    get('http://yourhost/api/content/readme.md')
    .then(response => console.log(response))

    // {
    //   "isDirectory": true,
    //   "content": ["readme.md", "license"]
    // }
```

*POST /api/content/{path}/{to}/{file}* - Set the content of a file, commit it to git and push to upstream. before invoking this action, you must read the file content and provide it's checksum as part of the request. You also need to provide a commit message.
example:
```
post('http://yourhost/api/content/readme.md', {
    "checksum": "5F251AC5FBC3DD0C0593296E5F9281239B8B660B503DD9234EBD49648831287B",
    "commit_message": "update readme",
    "content": "hello world 2!"
})
```


*PUT /api/content/{path}/{to}/{file}* - Creates a new file at the given path  
```
put('http://yourhost/api/content/new_readme.md', {
    "commit_message": "update readme",
    "content": "hello world 3!"
})
```