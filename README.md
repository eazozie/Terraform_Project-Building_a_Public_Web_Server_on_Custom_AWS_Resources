# Terraform Project: Building a Public Web Server on AWS using Terraform IaaC on a custom AWS VPC, Subnet, Security Groups, Route table, Internet Gateway, etc

### Disclaimer © Ebubechukwu Azozie
- All README content, source files, documentation, and screenshot images in this GitHub repository are original work created by me, **Ebubechukwu Azozie**. Unauthorized copying or reuse without proper attribution is not permitted.

## Resources used 
- AWS CLI Toolkit
- Terraform
- Package Manager - Chocolatey (for Windows - I use windows) or Homebrew (if you're using macOS)
- Visual Studio
- GitHub


### Outline/Steps used to deploy:
- Step 1. Create vpc
- Step 2. Create internet gateway
- Step 3. Create custom route table
- Step 4. Create a subnet
- Step 5. Associate subnet with route table
- Step 6. Create security group to allow port 22, 80, and 443
- Step 7. Create a network interface with an IP in the subnet that was created in step 4
- Step 8. Assign an elastic IP to the network interface created in step 7
- Step 9. Create an ubuntu server and installl and enable apache2
