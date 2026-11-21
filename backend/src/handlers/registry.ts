import {Request,Response} from 'express';
export type HandlerName='echo'|'encode'|'qr'|'unavailable';
export const handlers:Record<HandlerName,(req:Request,res:Response)=>unknown>={
 echo:(req,res)=>res.json({success:true,creator:'Roxy Main API',result:{message:`Roxy received: ${String(req.body?.message||'')}`,model:req.body?.model||'default'},timestamp:new Date().toISOString()}),
 encode:(req,res)=>{const text=String(req.body?.text||'');return res.json({success:true,result:{encoded:Buffer.from(text).toString('base64')}})},
 qr:(req,res)=>res.status(501).json({success:false,code:'HANDLER_NOT_CONFIGURED',message:'Connect a QR generation provider to enable this endpoint.'}),
 unavailable:(req,res)=>res.status(501).json({success:false,code:'HANDLER_NOT_CONFIGURED',message:'This endpoint is registered but its provider handler is not configured.'})
};
