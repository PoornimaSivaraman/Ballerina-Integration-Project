import ballerina/http;
import ballerinax/ai;

final ai:OpenAiProvider _FileIntegratorModel = check new (openAiApiKey, "gpt-4o");
final ai:Agent _FileIntegratorAgent = check new (
    systemPrompt = {role: "File Integrator", instructions: string `You are a math tutor assistant who helps students solve math problems. Provide clear, step-by-step instructions to guide them toward the final answer. Be sure to include the final answer at the end. Use the available tools to perform any necessary calculations.`}, model = _FileIntegratorModel, tools = []
);
