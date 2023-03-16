import ballerina/io;
import ballerinax/weaviate;
import ballerinax/openai;

configurable string openAIKey = ?;
configurable string weaviateKey = ?;
configurable string weaviateURL = ?;

public function main() returns error? {

    // create open-ai client
    openai:OpenAIClient openaiClient = check new ({
        auth: {
            token: openAIKey
        }
    });

    // create weaviate client
    weaviate:Client weaviateClient = check new({
        auth: {
            token: weaviateKey
        }
    }, weaviateURL);

    string query = "Set rate limit for Choreo";

    // retrieve open-ai ada embeddings for the query
    openai:CreateEmbeddingResponse embeddingResponse = check openaiClient->/embeddings.post({
            model: "text-embedding-ada-002",
            input: query
        }
    );

    // best practices? 
    decimal[] vector = embeddingResponse.data[0].embedding;
    string graphQLQuery =  string`{
                                Get {
                                    DocStore (
                                    nearVector: {
                                        vector: ${vector.toString()}
                                        }
                                        limit: 1
                                    ){
                                    docs
                                    _additional {
                                        certainty,
                                        id
                                        }
                                    }
                                }
                            }`;

    weaviate:GraphQLResponse|error results = check weaviateClient->/graphql.post({
        query: graphQLQuery
    });

    if (results is weaviate:GraphQLResponse){
        io:println(results);
    }
}