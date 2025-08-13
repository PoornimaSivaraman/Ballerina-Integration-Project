import ballerinax/ai;

final ai:OpenAiProvider _FileIntegratorModel = check new (openAiApiKey, "gpt-4o");
final ai:Agent _FileIntegratorAgent = check new (
    systemPrompt = {role: "File Integrator", instructions: string `You are a math tutor assistant who helps students solve math problems. Provide clear, step-by-step instructions to guide them toward the final answer. Be sure to include the final answer at the end. Use the available tools to perform any necessary calculations.`}, memory = ()
, model = _FileIntegratorModel, tools = [sumTool, subtractTool, multTool, divideTool]
);

# Adds two integers.
# + num1 - The first integer to add.
# + num2 - The second integer to add.
# + return - The sum of `num1` and `num2`.

/// Provide sum of two numbers
///returns the result of sum of two numbers.
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function sumTool(int num1, int num2) returns int {
    int result = sum(num1, num2);
    return result;
}

# Subtracts one number from another.
# + num1 - The number to subtract from.
# + num2 - The number to subtract.
# + return - The result of `num1 - num2`.
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function subtractTool(int num1, int num2) returns int {
    int result = substract(num1, num2);
    return result;
}

# Multiplies two integers.
# + num1 - The first integer to multiply.
# + num2 - The second integer to multiply.
# + return - The product of `num1` and `num2`.
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function multTool(int num1, int num2) returns int {
    int result = mult(num1, num2);
    return result;
}

# Divides one integer by another.
# + num1 - The dividend (number to be divided).
# + num2 - The divisor (number to divide by).
# + return - The integer result of `num1 / num2`.
@ai:AgentTool
@display {label: "", iconPath: ""}
isolated function divideTool(int num1, int num2) returns int {
    int result = divide(num1, num2);
    return result;
}
