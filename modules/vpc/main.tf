variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "ap-northeast-1"
}

# VPC作成
resource "aws_vpc" "honey-vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true # AWSのDNSサーバで名前解決有効
  enable_dns_hostnames = true # VPC内のリソースにパブリックDNSホスト名を自動割り当て有効
  tags = {
    Name = "honey-vpc"
  }
}

# サブネット作成 Public
resource "aws_subnet" "honey-public-subnet" {
  vpc_id                  = aws_vpc.honey-vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true # インスタンスにパブリックIP自動割り当て有効
  availability_zone       = "ap-northeast-1a"
  tags = {
    Name = "honey-public-subnet"
  }
}

# インターネットゲートウェイ作成
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.honey-vpc.id
  tags = {
    Name = "honey-igw"
  }
}

# ルートテーブル作成 Public
resource "aws_route_table" "honey-public-rt" {
  vpc_id = aws_vpc.honey-vpc.id
  tags = {
    Name = "honey-public-rt"
  }
}

# ルーティング設定 Public
resource "aws_route" "honey-public" {
  route_table_id         = aws_route_table.public-rt.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# サブネットとルートテーブルの紐付け
resource "aws_route_table_association" "honey-public" {
  subnet_id      = aws_subnet.-honey-public-subnet.id
  route_table_id = aws_route_table.honey-public-rt.id
}