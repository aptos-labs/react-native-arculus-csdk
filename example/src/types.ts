export type Command = {
  title: string;
  inputs?: string[];
  output: string;
  handler: (...args: any) => Promise<any>;
};

export type RootStackParamList = {
  Commands: undefined;
  Output: { command: Command };
};
