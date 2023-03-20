import ballerina/io;
import ballerinax/weaviate;
import ballerinax/openai.embeddings;

configurable string openAIKey = ?;
configurable string weaviateKey = ?;
configurable string weaviateURL = ?;
configurable string dataPath = ?;


public function main() returns error? {

    // create open-ai client
    embeddings:Client openaiClient = check new ({
        auth: {
            token: openAIKey
        }
    });

    // create weaviate client
    weaviate:Client weaviateClient = check new ({
        auth: {
            token: weaviateKey
        }
    }, weaviateURL);

    string className = "DocStore";
    string[] docsArray = [];
    weaviate:Object[] documentObjectArray = [];

    stream<string[], io:Error?> csvStream = check io:fileReadCsvAsStream(dataPath);
    // Iterates through the stream and extract the content
    check csvStream.forEach(function(string[] row) {
        weaviate:Object obj = {
            'class: className,
            properties: {
                "title": row[1],
                "docs": row[2],
                "url": row[3]
            }

        };
        documentObjectArray.push(obj);
        docsArray.push(row[2]);
    });

    embeddings:CreateEmbeddingResponse embeddingResponse = check openaiClient->/embeddings.post({
            model: "text-embedding-ada-002",
            input: docsArray
        }
    );

    foreach int i in 0 ... embeddingResponse.data.length() - 1 {
        documentObjectArray[i].vector = embeddingResponse.data[i].embedding;
    }

    weaviate:Batch_objects_body batch = {
        objects: documentObjectArray
    };

    weaviate:ObjectsGetResponse[] responseArray = check weaviateClient->/batch/objects.post(batch);

    foreach var res in responseArray {
        io:println(res);

    }
}
