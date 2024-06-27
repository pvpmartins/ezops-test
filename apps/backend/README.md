# rest-api-ezops-test

## Requirements 
- Node 14
- Postgres 11
## How to Start the API

1. Clone repo: git clone https://github.com/ezops-br/rest-api-ezops-test.git

2. Install Dependencies: npm install

3. Setup the database postgres 11

4. Run SQL file database/create.sql

5. Setup Environment variables: DB_USER, DB_PASSWORD, DB_HOST, DB_PORT, DB_NAME

6. Run the server: node server/server.js

## How to Test the API

1. Use Postman

2. Follow the test

```
GET https://<yourname>.com/posts
POST https://yoururl.com/posts
{
    "title" : "Post",
    "content" : "Post content"
}
PUT https://yoururl.com/posts/1
{
    "title" : "Edited post",
    "content" : "Edited post content"
}
DELETE https://yoururl.com/posts/1
```
