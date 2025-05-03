terraform { 
  cloud { 
    
    organization = "hellocloud-aws-master-account" 

    workspaces { 
      name = "eks-game" 
    } 
  } 
}