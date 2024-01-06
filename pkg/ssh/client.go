package ssh

import (
	"bytes"
	"fmt"
	"io"
	"os"
	"path/filepath"

	"golang.org/x/crypto/ssh"
)

type Client struct {
	client *ssh.Client
}

func NewClient(host, user, password string) (*Client, error) {
	config := &ssh.ClientConfig{
		User: user,
		Auth: []ssh.AuthMethod{
			ssh.Password(password),
		},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
		// TODO: In production, use ssh.FixedHostKey(publicKey) instead
	}

	client, err := ssh.Dial("tcp", fmt.Sprintf("%s:22", host), config)
	if err != nil {
		return nil, fmt.Errorf("failed to dial: %v", err)
	}

	return &Client{client: client}, nil
}

func (c *Client) ExecuteScript(scriptPath string) (string, error) {
	// Read local script file
	content, err := os.ReadFile(scriptPath)
	if err != nil {
		return "", fmt.Errorf("failed to read script: %v", err)
	}

	// Create new session
	session, err := c.client.NewSession()
	if err != nil {
		return "", fmt.Errorf("failed to create session: %v", err)
	}
	defer session.Close()

	// Create temporary file on remote host
	remoteScript := fmt.Sprintf("/tmp/%s", filepath.Base(scriptPath))
	err = c.transferFile(bytes.NewReader(content), remoteScript, 0755)
	if err != nil {
		return "", fmt.Errorf("failed to transfer script: %v", err)
	}

	// Execute script with explicit bash interpreter
	var outputBuffer bytes.Buffer
	session.Stdout = &outputBuffer

	if err := session.Run(fmt.Sprintf("bash %s", remoteScript)); err != nil {
		return "", fmt.Errorf("failed to run script: %v", err)
	}

	// Cleanup temp file
	c.executeCommand(fmt.Sprintf("rm -f %s", remoteScript))

	return outputBuffer.String(), nil
}

func (c *Client) transferFile(content io.Reader, remotePath string, mode os.FileMode) error {
	session, err := c.client.NewSession()
	if err != nil {
		return err
	}
	defer session.Close()

	var remoteBuffer bytes.Buffer
	remoteBuffer.WriteString(fmt.Sprintf("C%#o %d %s\n", mode, 0, filepath.Base(remotePath)))

	if _, err := io.Copy(&remoteBuffer, content); err != nil {
		return err
	}

	remoteBuffer.WriteString("\x00")
	session.Stdin = &remoteBuffer

	return session.Run(fmt.Sprintf("cat > %s", remotePath))
}

func (c *Client) executeCommand(cmd string) error {
	session, err := c.client.NewSession()
	if err != nil {
		return err
	}
	defer session.Close()

	return session.Run(cmd)
}

func (c *Client) Close() error {
	return c.client.Close()
}
