# resterampe-terraform

## dev

```bash
  terraform workspace select dev
  terraform apply
```

## live

```bash
  terraform workspace select live
  terraform apply -var 'env=live'
```
