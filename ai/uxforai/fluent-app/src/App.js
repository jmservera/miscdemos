import logo from './logo.svg';
import './App.css';
import * as React from 'react';
import { webLightTheme, FluentProvider, Text } from '@fluentui/react-components';
import { OutputCard } from '@fluentui-copilot/react-copilot';
import { CopilotProvider } from '@fluentui-copilot/react-copilot';

import {
  makeStyles,
  shorthands,
  teamsDarkTheme,
  teamsLightTheme,
  tokens,
  Button,
} from "@fluentui/react-components";

const useStyles = makeStyles({
  button: {
    marginTop: "5px",
  },
  provider: {
    ...shorthands.border("1px"),
    ...shorthands.borderRadius("5px"),
    ...shorthands.padding("5px"),
  },
  text: {
    backgroundColor: tokens.colorBrandBackground2,
    color: tokens.colorBrandForeground2,
    fontSize: "20px",
    ...shorthands.border("1px"),
    ...shorthands.borderRadius("5px"),
    ...shorthands.padding("5px"),
  },
});


function App() {
  const styles = useStyles();
  return (
    <div className="App">
      <header className="App-header">

      <FluentProvider theme={webLightTheme}>
      <CopilotProvider
        mode="sidecar" //or 'canvas'
        themeExtension={{
          colorBrandFlair1: 'red', // replace with your brand colors
          colorBrandFlair2: 'blue',
          colorBrandFlair3: 'green',
        }}
      >
        <OutputCard progress={{ value: undefined }} isLoading>
          <Text>Welcome to Fluent AI Copilot</Text>
        </OutputCard>
      </CopilotProvider>
    </FluentProvider>

      </header>
    </div>




);
}

export default App;
