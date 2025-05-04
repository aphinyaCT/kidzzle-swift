//
//  PrivacyPolicyView.swift
//  Kidzzle
//
//  Created by aynnipa on 5/3/2568 BE.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Binding var agreed: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("นโยบายและความเป็นส่วนตัว")
                        .foregroundColor(.jetblack)
                        .font(customFont(type: .bold, textStyle: .title3))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                Text("วันที่ 14 พฤษภาคม 2568")
                    .font(customFont(type: .regular, textStyle: .footnote))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        policySection(content: [
                            "โมไบล์แอปพลิเคชัน KIDZZLE คิดส์เซิล เป็นผลงานวิจัยนวัตกรรมสื่อสารนิพนธ์ที่พัฒนาโดย นายก้องภพ ทิมภราดร และ นางสาวอภิญญา ปานทวีเกียรติ วิทยาลัยนวัตกรรมสื่อสารสังคม มหาวิทยาลัยศรีนครินทรวิโรฒ มีบันทึกข้อตกลงและขออนุญาตใช้เนื้อหากับกรมอนามัย กระทรวงสาธารณสุข",
                            
                            "เราพัฒนาและปรับปรุงระบบแพลตฟอร์มและโมไบล์แอปพลิเคชัน KIDZZLE คิดส์เซิล อยู่ตลอดเวลาเพื่อให้คนไทยเข้าถึงการดูแลสุขภาพของบุตรได้ดียิ่งขึ้น ซึ่งส่วนสำคัญที่จะทำให้ผู้ใช้มีประสบการณ์การใช้งานที่ดีคือการดูแลข้อมูลของบุตร โดยให้ความสำคัญกับความเป็นส่วนตัวของผู้ใช้ และควบคุมความปลอดภัยในการเก็บและเข้าถึงข้อมูล",
                            
                            "ผู้ใช้สามารถให้ความยินยอมในการเข้าถึงข้อมูลส่วนบุคคล ในหัวข้อย่อยดังต่อไปนี้"
                        ])
                        
                        policySectionWithHeader(
                            title: "การยินยอมในการสำรองข้อมูลในระบบคลาวด์ KIDZZLE",
                            content: "เมื่อผู้ใช้ยินยอม ผู้ใช้จะสามารถบันทึกข้อมูลในโมไบล์แอปพลิเคชัน KIDZZLE ได้ และข้อมูลที่ผู้ใช้บันทึกจะถูกส่งไปสำรองในแพลตฟอร์มคลาวด์ KIDZZLE โดยข้อมูลที่ส่งมานั้นมีการเข้ารหัส (Encrypt) และสามารถเข้าถึงได้โดยบัญชีผู้ใช้ ซึ่งจะต้อง Login ด้วย ชื่อผู้ใช้งาน (Username) และ รหัสผ่าน (Password) ที่ถูกต้องตรงกับที่ผู้ใช้ที่ลงทะเบียนไว้ในโมไบล์แอปพลิเคชัน KIDZZLE"
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("การยินยอมให้ KIDZZLE ใช้ข้อมูลโดยไม่ระบุตัวตน")
                                .foregroundColor(.jetblack)
                                .font(customFont(type: .semibold, textStyle: .callout))
                            
                            Text("ผู้ใช้สามารถเลือกที่จะยินยอม หรือไม่ให้ความยินยอมก็ได้ ให้เรานำข้อมูลที่ไม่ระบุตัวตนของท่านไปใช้ดังนี้")
                                .foregroundColor(.jetblack)
                                .font(customFont(type: .regular, textStyle: .callout))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                bulletPoint("ให้ใช้ข้อมูลสถานะทางสุขภาพ")
                                bulletPoint("ให้ใช้ข้อมูลเพื่อปรับปรุงการทำงานของแอปพลิเคชัน")
                            }
                            .padding(.leading, 8)
                        }
                        
                        // ระยะเวลาในการเก็บข้อมูล
                        policySectionWithHeader(
                            title: "ระยะเวลาในการเก็บข้อมูลของท่าน",
                            content: "ข้อมูลที่ท่านทำการสำรองไว้ จะถูกเก็บไว้ตราบที่ท่านใช้งานแอปพลิเคชันอยู่ หากท่านต้องการให้ลบข้อมูลที่ได้สำรองไว้ออกจากแพลตฟอร์มคลาวด์ KIDZZLE สามารถติดต่อทางอีเมลมายัง kongpop.timp@gmail.com หรือ aphinya.pant@gmail.com โดยใช้ชื่ออีเมลที่ตรงกับชื่อผู้ใช้ที่ท่านได้ลงทะเบียนไว้ และผู้พัฒนาจะดำเนินการลบบัญชีและข้อมูลที่ได้สำรองไว้"
                        )
                        
                        // ความปลอดภัยในการเก็บข้อมูล
                        policySectionWithHeader(
                            title: "ความปลอดภัยในการเก็บข้อมูลของท่าน",
                            content: "ผู้พัฒนาได้ตระหนักถึงความปลอดภัยในการเก็บข้อมูลของท่าน เราได้ใช้มาตรการทางกายภาพ (Physical) อิเล็กทรอนิก (Electronic) และ กระบวนการการทำงาน (Procedural) ที่จะปกปัองข้อมูลในระบบเครื่องแม่ข่าย อาทิเช่น การจำกัดสิทธิ์ในการเข้าถึงระบบเฉพาะพนักงานและผู้รับเหมาผู้ที่จำเป็นต้องเข้าถึงเพื่อการให้บริการ พัฒนา ปรับปรุงแอปพลิเคชัน"
                        )
                        
                        // การเปลี่ยนแปลงนโยบาย
                        policySectionWithHeader(
                            title: "การเปลี่ยนแปลงนโยบายความเป็นส่วนตัว",
                            content: "นโยบายความเป็นส่วนตัวนี้อาจมีการเปลี่ยนแปลง ผู้พัฒนาจะนำนโยบายความเป็นส่วนตัวใหม่มาประกาศที่นี่ ผู้ใช้งานสามารถเข้ามาดูนโยบายได้ตลอดเวลา การใช้แอปพลิเคชันถือเป็นการยอมรับในนโยบายความเป็นส่วนตัว"
                        )
                        
                        // ติดต่อเรา
                        policySectionWithHeader(
                            title: "ติดต่อเรา",
                            content: "สามารถติดต่อสอบถามเกี่ยวกับนโยบายความเป็นส่วนตัวหรือการทำงานของแอปพลิเคชัน ได้ทางอีเมลที่ kongpop.timp@gmail.com หรือ aphinya.pant@gmail.com"
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                
                Button(action: {
                    agreed.toggle()
                }, label: {
                    Text("ยอมรับ")
                        .font(customFont(type: .semibold, textStyle: .body))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(.jetblack)
                        .cornerRadius(10)
                })
                .contentShape(.rect)
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
            }
            .background(.ivorywhite)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    @ViewBuilder
    private func policySection(content: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(content, id: \.self) { paragraph in
                Text(paragraph)
                    .font(customFont(type: .regular, textStyle: .callout))
                    .foregroundColor(.jetblack)
            }
        }
    }
    
    @ViewBuilder
    private func policySectionWithHeader(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(customFont(type: .semibold, textStyle: .callout))
                .foregroundColor(.jetblack)
            
            Text(content)
                .font(customFont(type: .regular, textStyle: .callout))
                .foregroundColor(.jetblack)
        }
    }
    
    @ViewBuilder
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(customFont(type: .regular, textStyle: .callout))
                .foregroundColor(.jetblack)
            
            Text(text)
                .font(customFont(type: .regular, textStyle: .callout))
                .foregroundColor(.jetblack)
        }
    }
}

#Preview {
    PrivacyPolicyView(agreed: .constant(false))
}
