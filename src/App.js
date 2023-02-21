import React from 'react';

import '@rainbow-me/rainbowkit/styles.css';

import { ConnectButton, RainbowKitProvider, lightTheme } from '@rainbow-me/rainbowkit';
import { ChakraProvider, Container, Heading, extendTheme, Box, Flex, Button, VisuallyHidden } from '@chakra-ui/react';
import { useAccount } from 'wagmi';

import PlayGame from './components/PlayGame';

const theme = extendTheme({
  styles: {
    global: () => ({
      body: {
        bg: '#fdffcd',
      }
    })
  },
})

function App(props) {
  const {data: accountdata} = useAccount();
  return (
    <RainbowKitProvider chains={props.chains} theme={lightTheme({
      accentColor: 'red'
    })}>
      <ChakraProvider theme={theme}>
        <Container maxW='xl' background="#fdffcd">

          <Heading textAlign="center" pt="10">tasty DApp 🤑</Heading>
          <Box display="flex" alignItems="center" justifyContent="center" p="5">
            <ConnectButton />
            
          </Box>
          

          <PlayGame />
        
          
        </Container>
      </ChakraProvider>
    </RainbowKitProvider>
  );
}

export default App;
