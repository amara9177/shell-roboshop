
resource "aws_instance" "terraform"{ #terraform is a instance name like redis mongodb
    ami ="ami-09c813fb71547fc4f" 
    instance_type= "t3.micro"
    vpc_security_group_ids = [aws_security_group.allow_all.id]
     tags = {
        Name= "terraform"
        Terraform="true"
     }
}
resource "aws_security_group" "allow_all" { #we can give name of the resource here like allow all
  name        = "allow_all"
 
    egress { # Egress rules (outbound traffic)
    from_port   = 0 #from_ port 0 to to_port 0 means all ports #ports are the end points they decide which data enters or leaves over network
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"] #internet
   }

  ingress { # ingress rules (outbound traffic)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
    }

 }
