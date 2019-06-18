<h1>Transfer Digital Records Terraform</h1>

<h2>Purpose</h2>

<p>Prototype project to outline a possible structure for Terraform to provision AWS resources for the Transfer of Digital Recordss (TDR) project</p>

<h2>Terraform Structure</h2>

<p>The prototype is divided into separate Terraform modules that represent the different AWS resources that are needed to for the TDR project. Not all resources are covered as the prototype provides the overall structure.</p>

<p>The modules are:</p>
<li>
  <item>
    <p>cognito: provisions two skelton user groups and relevant App Clients</p>
  </item>
</li>
  <li>
  <item>
    <p>stepfunction: provisions a skeleton step function that uses information (vpc id) from the vpc module</p>
  </item>
</li>
  <li>
  <item>
    <p>vpc: provisions a skeleton vpc that exposes its id to other modules</p>
  </item>
</li>

<h2>Getting Started</h2>

<h3>Install Terraform locally</h3>

<p>See: https://learn.hashicorp.com/terraform/getting-started/install.html</p>

<h3>Running the Terraform project</h3>

<p>Navigate to location of the toplevel main.tf file in a command shell</p>

<p>Run the following command: $ terraform init (this will initialize Terraform on your local machine)</p>

<p>Run the following command: $ terraform apply -var="access_key=[your aws access key]" -var="secret_key=[your aws secret key]" -var="region=[aws region]"</p>

<p>Instead of entering the vars on the command line you can create a local variable file (terraform.tfvars) at the top level of the project) and use this. NOTE do not commit this file as you will be exposing your AWS credentials.</p>

<p>Once the Terraform apply command successfully executes you can check you AWS account and see the resources created</p>

<p><b>NOTE: PLEASE DELETE THE RESOURCES CREATED AFTER YOU HAVE FINISHED</b></p>

<h2>Further Information</h2>

<p>Terraform website: https://www.terraform.io/</p>

<p>Terraform basic tutorial: https://learn.hashicorp.com/terraform/getting-started/build</p>
