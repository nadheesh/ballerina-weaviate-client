# Ballerina weaviate client

Usage 
- Build the client package and push to local repository
    ```
    $ cd weaviate
    $ bal pack
    $ bal push --repository local
    ```
- Set the Weaviate key in the Config.toml

    ```
    $ cd sample
    $ echo "weaviateKey = \"sk-xxxxxxxxxxxxxxxxxxxxxxxxxxx\"" > Config.toml
    ```
- Run main with an argument 
    ```
    sample$ bal run -- "What is Ballerina"
    ```