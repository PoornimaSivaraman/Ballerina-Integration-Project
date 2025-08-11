import ballerinax/ai;

final ai:OpenAiProvider _FileIntegratorModel = check new ("", ai:GPT_4O);
final ai:Agent _FileIntegratorAgent = check new (systemPrompt = {role: "", instructions: string ``},
    model = _FileIntegratorModel,
    tools = []
);